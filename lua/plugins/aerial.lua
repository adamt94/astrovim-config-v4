---@type LazySpec
return {
  "stevearc/aerial.nvim",
  commit = "3c04b040a81b800125d7f68f5579892d6bce854d",
  config = function(_, opts)
    local backends = require "aerial.backends"
    local config = require "aerial.config"
    local helpers = require "aerial.backends.treesitter.helpers"
    local treesitter = require "aerial.backends.treesitter"

    if not helpers._nvim_012_compat then
      helpers._nvim_012_compat = true
      local function resolve_node(node, pick_last)
        if type(node) == "table" then node = node[pick_last and #node or 1] end
        return node
      end

      local function normalize_capture_node(name, node)
        if type(node) == "table" and vim.islist(node) then
          return node[name == "end" and #node or 1]
        end
        return node
      end

      helpers.range_from_nodes = function(start_node, end_node)
        start_node = resolve_node(start_node, false)
        end_node = resolve_node(end_node, true)
        local row, col, end_row, end_col

        if type(start_node.range) == "function" and type(end_node.range) == "function" then
          row, col = start_node:range()
          _, _, end_row, end_col = end_node:range()
        else
          row, col = start_node:start()
          end_row, end_col = end_node:end_()
        end

        return {
          lnum = row + 1,
          end_lnum = end_row + 1,
          col = col,
          end_col = end_col,
        }
      end

      treesitter.fetch_symbols_sync = function(bufnr)
        bufnr = bufnr or 0
        local extensions = require "aerial.backends.treesitter.extensions"
        local get_node_text = vim.treesitter.get_node_text
        local include_kind = config.get_filter_kind_map(bufnr)
        local parser = helpers.get_parser(bufnr)
        local items = {}
        if not parser then
          backends.set_symbols(bufnr, items, { backend_name = "treesitter", lang = "unknown" })
          return
        end

        local lang = parser:lang()
        local syntax_tree = parser:parse()[1]
        local query = helpers.get_query(lang)
        if not query or not syntax_tree then
          backends.set_symbols(
            bufnr,
            items,
            { backend_name = "treesitter", lang = lang, syntax_tree = syntax_tree }
          )
          return
        end

        local stack = {}
        local ext = extensions[lang]
        for _, matches, metadata in query:iter_matches(syntax_tree:root(), bufnr, nil, nil, { all = false }) do
          local match = vim.tbl_extend("force", {}, metadata)
          for id, node in pairs(matches) do
            local capture_name = query.captures[id]
            match = vim.tbl_extend("keep", match, {
              [capture_name] = {
                metadata = metadata[id],
                node = normalize_capture_node(capture_name, node),
              },
            })
          end

          local name_match = match.name or {}
          local selection_match = match.selection or {}
          local symbol_node = (match.symbol or match.type or {}).node
          local start_node = (match.start or {}).node or symbol_node
          local end_node = (match["end"] or {}).node or start_node
          local parent_item, parent_node, level = ext.get_parent(stack, match, symbol_node)

          if symbol_node and symbol_node ~= parent_node then
            local kind = match.kind
            if not kind then
              vim.api.nvim_err_writeln(string.format("Missing 'kind' metadata in query file for language %s", lang))
              break
            elseif not vim.lsp.protocol.SymbolKind[kind] then
              vim.api.nvim_err_writeln(
                string.format("Invalid 'kind' metadata '%s' in query file for language %s", kind, lang)
              )
              break
            end

            local range = helpers.range_from_nodes(start_node, end_node)
            local selection_range
            if selection_match.node then
              selection_range = helpers.range_from_nodes(selection_match.node, selection_match.node)
            end

            local name
            if name_match.node then
              name = get_node_text(name_match.node, bufnr, name_match) or "<parse error>"
              if not selection_range then
                selection_range = helpers.range_from_nodes(name_match.node, name_match.node)
              end
            else
              name = "<Anonymous>"
            end

            local scope
            if match.scope and match.scope.node then
              scope = get_node_text(match.scope.node, bufnr, match.scope)
            else
              scope = match.scope
            end

            local item = {
              kind = kind,
              name = name,
              level = level,
              parent = parent_item,
              selection_range = selection_range,
              scope = scope,
            }
            for k, v in pairs(range) do
              item[k] = v
            end

            if ext.postprocess(bufnr, item, match) ~= false and include_kind[item.kind] then
              local ctx = {
                backend_name = "treesitter",
                lang = lang,
                syntax_tree = syntax_tree,
                match = match,
              }
              if not config.post_parse_symbol or config.post_parse_symbol(bufnr, item, ctx) ~= false then
                if item.parent then
                  if not item.parent.children then item.parent.children = {} end
                  table.insert(item.parent.children, item)
                else
                  table.insert(items, item)
                end
                table.insert(stack, { node = symbol_node, item = item })
              end
            end
          end
        end

        ext.postprocess_symbols(bufnr, items)
        backends.set_symbols(
          bufnr,
          items,
          { backend_name = "treesitter", lang = lang, syntax_tree = syntax_tree }
        )
      end
      treesitter.fetch_symbols = treesitter.fetch_symbols_sync
    end

    require("aerial").setup(opts)
  end,
}
