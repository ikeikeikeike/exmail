defmodule Exmail.Tasks.Cleanup do
  def unses_files do
    args = [
      System.tmp_dir,
      "-maxdepth", "1" ,
      "-type", "f",
      "-user", System.get_env["USER"],
      "-mtime", "+10",
      "-exec", "rm", "{}", "\\;"]

    :os.cmd 'find #{Enum.join args, " "}'
  end
end
