local M = {}

local function create_terminal(command)
  local buf = vim.api.nvim_create_buf(false, true)

  local obj = vim.system({ "sh", "-c", command }, { text = true }):wait()
  if obj.code ~= 0 then
    vim.api.nvim_err_writeln(obj.stderr or ("Command exited with code " .. obj.code))
    return
  end

  if obj.stdout and obj.stdout ~= "" then
    vim.api.nvim_open_win(buf, true, { split = "below", height = 10 })
    vim.api.nvim_buf_set_lines(
      buf,
      0,
      -1,
      false,
      vim.split(obj.stdout, "\n", { plain = true })
    )

    vim.keymap.set("n", "<CR>", function()
      vim.api.nvim_buf_delete(buf, { force = true })
    end, { buffer = buf, nowait = true })

    vim.keymap.set("n", "q", function()
      vim.api.nvim_buf_delete(buf, { force = true })
    end, { buffer = buf, nowait = true })
  end
end

function M.setup()
  vim.api.nvim_create_user_command("Cmd", function(opts)
    create_terminal(opts.args)
  end, { nargs = "+" })

  vim.keymap.set("n", "<leader>ts", function()
    vim.ui.input({ prompt = "cmd: " }, function(cmd)
      if cmd then
        create_terminal(cmd)
      end
    end)
  end)
end

return M
