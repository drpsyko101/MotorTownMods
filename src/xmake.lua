local projectName = "MotorTownMods"

add_requires("boost",  { debug = is_mode_debug(), configs = {runtimes = get_mode_runtimes(), all = true} , system = false})

target(projectName)
    add_rules("ue4ss.mod")
    add_includedirs(".")
    add_headerfiles("src/*.h")
    add_files("src/*.cpp")
    add_packages("boost")
    add_defines("_CRT_SECURE_NO_WARNINGS")
