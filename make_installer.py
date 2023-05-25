import os

minify = False

if minify:
    os.system("sh minify.sh")
    install_path = "minified"
else:
    install_path = "real_src"

installer_file = \
"""
for k, v in pairs({LEFT}{MAKE_DIRS}{RIGHT}) do
    pcall(function() fs.makeDir(v) end)
end
for k, v in pairs({LEFT}{PROGRAMS}{RIGHT}) do
    local file = fs.open(k, "w")
    file.write(v)
    file.close()
end
"""

dirs = []
src_files = []

for root, dir, files in os.walk(install_path):
    root = root.split("/")[1::]
    if len(root) > 0:
        dirs.append(f'\"{"/".join(root)}\"')
    for file in files:
        path = "/".join([install_path] + root + [file])
        with open(path, mode="r") as f:
            data = f.read()
        src_files.append([
            "/".join(root + [file]),
            data
        ])


programs = []
for path, data in src_files:
    data = data.replace("\\n", "\\\\n")
    data = data.replace("\n", "\\n")
    data = data.replace("\"", "\\\"")
    programs.append(f"[\"{path}\"]=\"{data}\"")
programs = ",".join(programs)

installer_file = installer_file.format(LEFT="{", RIGHT="}",
                   MAKE_DIRS=",".join(dirs),
                   PROGRAMS=programs)

with open("installer.lua", mode="w") as file:
    file.write(installer_file)