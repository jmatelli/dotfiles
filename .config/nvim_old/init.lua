vim.filetype.add({
    extension = {
        mdx = "mdx",
    },
})

require("options")
require("mappings")
require("commands")
require("diagnostics")

require("config.files")
require("config.lazy")
