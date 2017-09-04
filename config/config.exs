# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :build_server, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:build_server, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
config :quantum,
  timezone: :local

config :build_server,
home_dir: ~S"C:\AX\Build\WAXR3\build_server",
scripts_dir: ~S"C:\AX\Build\WAXR3\build_scripts",
scripts_share: ~S"\\MOW04DEV014\build_scripts",
scripts_share: ~S"\\MOW04WAXBLD01\Ax\Build\Scripts",
systems: [WaxR3],
build_configuration:
  %{
    WaxR3:
      %{
        "VCSFilePath" => "C:/Program Files/Microsoft Dynamics AX/60/Server/Microsoft Dynamics AX/bin/Application/WAXR3/Definition/VCSDef.xml",
        "ApplicationSourceDir" => "C:/Program Files/Microsoft Dynamics AX/60/Server/Microsoft Dynamics AX/bin/Application/WAXR3",
        "DropLocation" => "C:/Ax/Build/Drop/WaxR3",
        "CompileAll" => "true",
        "CleanupAfterBuild" => "true",
        "CompileCIL" => "true",
        "TFSIntegration" => "true",
        "TFSUrl" => "https://mediamarkt.visualstudio.com/defaultcollection",
        "TFSLabelPrefix" => "WAXR3-{0}",
        "TFSWorkspace" => "$/WAXR3/WAXR3",
        "LabelComments" => "WAX R3 Build-{0}",
        "MsBuildDir" => "C:/Program Files (x86)/MSBuild/12.0/Bin",
        "NoCleanOnError" => "true",
        "BackupModelStoreFolder" => "C:/Ax/Build/Backup/Modelstore",
        "CleanBackupFileName" => "C:/Program Files/Microsoft SQL Server/MSSQL12.MSSQLSERVER/MSSQL/Backup/MicrosoftDynamicsAX.bak"
      }
  },
deploy_configuration: 
  %{
    WaxR3:
      %{
        "BuildLocation" => ~S"\\MOW04DEV014\Drop\WaxR3",
        "MsBuildDir" => "C:/Program Files/(x86)/MSBuild/12.0/Bin",
        "CompileAll" => true,
        "CompileCil" => true,
        "UninstallOnly" => false,
        "TFSIntegration" => true,
        "TFSURL" => "https://mediamarkt.visualstudio.com/defaultcollection",
        "TFSWorkspace" => "$WAXR3/WAXR3",
        "NoCleanOnError" => true,
        "InstallModelStore" => true,
        "SystemName" => "WAXR3"
        }
    },
    commands:
      %{
        "deploy" => "Format: deploy system_name.\nStarts deploy process right away.",
        "schedule_deploy" => "Format: schedule_deploy system_name schedule.\nSchedules deploy processes at the specified schedule.",
        "h" => "Short for 'help'.\nFormat: h [command].\nDisplays general help or help for a given command.",
        "help" => "Format: help [coommand].\nDisplays general help or helr for a given command.",
        "get_configuration" => "Format: get_configuration system.\nDisplays deployment configuration parameters for a given system.",
        "list_commands" => "Lists commands available.",
        "list_systems" => "Lists valid systems.",
        "schedule_build" => "Format: schedule_build system_name schedule\nSchedules build of the system at a given schedule.",
        "build" => "Format: build system.\nStarts build process of the given system right away.",
        "get_build_configuration" => "Format: get_build_configuration system_name\nDisplays build configuration parameters for a given system.",
        "get_build_info" => "Format: get_build_info system_name\nQueries build information, such as latest build and last successful build number for a given system_name.",
        "schedule_ping" => "Format: schedule_ping schedule.\nSchedules a 'ping' to the current build client console.",
        "my_client" => "Displays build client console active client information. For AX Build Administrator.",
        "my_schedule" => "Displays schedules defined for the current host.",
        "remove_schedule" => "Format: remove_schedule schedule\nRemoves all schedules at the given time for the current host.",
        "clear_schedule" => "Clears, i.e., removes all the schedules defined for the current host."
      }
