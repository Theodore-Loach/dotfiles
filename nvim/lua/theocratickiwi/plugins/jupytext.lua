return {
  {
    "GCBallesteros/jupytext.nvim",
    -- Depending on your nvim distro or config you may need to make the loading not lazy
    -- lazy=false,
    config = function()
      require("jupytext").setup({
        style = "markdown",
        output_extension = "md",
        force_ft = "markdown",
      })
    end,
  }
}
