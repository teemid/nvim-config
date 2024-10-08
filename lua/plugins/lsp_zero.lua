return {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v4.x',
    dependencies = {
        {'neovim/nvim-lspconfig'},
        {'hrsh7th/cmp-nvim-lsp'},
        {'hrsh7th/nvim-cmp'},
        {'williamboman/mason.nvim'},
        {'williamboman/mason-lspconfig.nvim'},
    },
    config = function()
        local lsp_zero = require('lsp-zero')

        -- lsp_attach is where you enable features that only work
        -- if there is a lanuage server active in the file
        local lsp_attach = function(client, bufnr)
            local opts = {buffer = bufnr}

            -- lsp_zero.default_keymaps(opts)
            vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
            vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
            vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
            vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
            vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
            vim.keymap.set({'n', 'x'}, '<leader>vcf', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
            vim.keymap.set('n', '<leader>vd', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
            vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_next()<cr>', opts)
            vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_prev()<cr>', opts)
            vim.keymap.set('n', '<leader>vca', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
            vim.keymap.set('n', '<leader>vrn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
            vim.keymap.set('n', '<leader>vrr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
            vim.keymap.set('n', '<leader>vws', '<cmd>lua vim.lsp.buf.workspace_symbol()<cr>', opts)
            vim.keymap.set('n', '<C-h>', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)

            if client.name == 'clangd' then
                vim.keymap.set('n', '<leader>ssh', '<cmd>lua vim.cmd("ClangdSwitchSourceHeader")<cr>', opts)
            end
        end

        lsp_zero.extend_lspconfig({
            sign_text = true,
            lsp_attach = lsp_attach,
            capabilities = require('cmp_nvim_lsp').default_capabilities(),
        })

        -- NOTE (Emil): This is a workaround because when clangd and copilot are
        -- attached to the same buffer you get a warning each time you interact
        -- with clangd. Because clangd and copilot are using two different
        -- encoding offsets (utf-8 and utf-16)
        local cmp_nvim_lsp = require "cmp_nvim_lsp"
        require("lspconfig").clangd.setup({
            capabilities = cmp_nvim_lsp.default_capabilities(),
            cmd = {
                "clangd",
                "--offset-encoding=utf-16",
            },
        })

        require('mason').setup({})
        require('mason-lspconfig').setup({
            handlers = {
                function(server_name)
                    require('lspconfig')[server_name].setup({})
                end,
            }
        })

        local cmp = require('cmp')

        cmp.setup({
            sources = {
                {name = 'nvim_lsp'},
            },
            snippet = {
                expand = function(args)
                    vim.snippet.expand(args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({}), 
        })
    end,
}
