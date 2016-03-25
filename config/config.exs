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
home_dir: "C:/Users/pyatkov/build_server_w_localtime",
scripts_dir: "C:/AX/BuildScripts",
systems: [Lips, Wax, Fax],
build_configuration:
  %{
    Fax:
      %{
        "VCSFilePath" => "C:/Program Files/Microsoft Dynamics AX/60/Server/AXTest/bin/Application/FAX/Definition/VCSDef.xml",
        "ApplicationSourceDir" => "C:/Program Files/Microsoft Dynamics AX/60/Server/AXTest/bin/Application/FAX",
        "DropLocation" => "C:/AX/Build/Drop/Fax",
        "CompileAll" => "true",
        "CleanupAfterBuild" => "true",
        "CompileCIL" => "true",
        "TFSIntegration" => "true",
        "TFSUrl" => "https://mediamarkt.visualstudio.com/defaultcollection",
        "TFSLabelPrefix" => "FAX-{0}",
        "TFSWorkspace" => "$/FAX/FAX",
        "LabelComments" => "FAX Build-{0}",
        "MsBuildDir" => "C:/Program Files (x86)/MSBuild/12.0/Bin",
        "NoCleanOnError" => "true",
        "BackupModelStoreFolder" => "C:/AX/Backup/Modelstore",
        "CleanBackupFileName" => "C:/Program Files/Microsoft SQL Server/MSSQL12.MSSQLSERVER/MSSQL/Backup/AXR3.bak"
      },
    Wax:
      %{
        "VCSFilePath" => "C:/Program Files/Microsoft Dynamics AX/60/Server/AXTest/bin/Application/WAX/Definition/VCSDef.xml",
        "ApplicationSourceDir" => "C:/Program Files/Microsoft Dynamics AX/60/Server/AXTest/bin/Application/WAX",
        "DropLocation" => "C:/AX/Build/Drop/Wax",
        "CompileAll" => "true",
        "CleanupAfterBuild" => "true",
        "CompileCIL" => "true",
        "TFSIntegration" => "true",
        "TFSUrl" => "https://mediamarkt.visualstudio.com/defaultcollection",
        "TFSLabelPrefix" => "WAX-{0}",
        "TFSWorkspace" => "$/WAX/FAX",
        "LabelComments" => "WAX Build-{0}",
        "MsBuildDir" => "C:/Program Files (x86)/MSBuild/12.0/Bin",
        "NoCleanOnError" => "true",
        "BackupModelStoreFolder" => "C:/AX/Backup/Modelstore",
        "CleanBackupFileName" => "C:/Program Files/Microsoft SQL Server/MSSQL12.MSSQLSERVER/MSSQL/Backup/AXR3.bak"
      },
    Lips:
      %{
        "VCSFilePath" => "C:/Program Files/Microsoft Dynamics AX/60/Server/AXTest/bin/Application/LIPS/Definition/VCSDef.xml",
        "ApplicationSourceDir" => "C:/Program Files/Microsoft Dynamics AX/60/Server/AXTest/bin/Application/LIPS",
        "DropLocation" => "C:/AX/Build/Drop/Lips",
        "CompileAll" => "true",
        "CleanupAfterBuild" => "true",
        "CompileCIL" => "true",
        "TFSIntegration" => "true",
        "TFSUrl" => "https://mediamarkt.visualstudio.com/defaultcollection",
        "TFSLabelPrefix" => "LIPS-{0}",
        "TFSWorkspace" => "$/LIPS/LIPS",
        "LabelComments" => "LIPS Build-{0}",
        "MsBuildDir" => "C:/Program Files (x86)/MSBuild/12.0/Bin",
        "NoCleanOnError" => "true",
        "BackupModelStoreFolder" => "C:/AX/Backup/Modelstore",
        "CleanBackupFileName" => "C:/Program Files/Microsoft SQL Server/MSSQL12.MSSQLSERVER/MSSQL/Backup/AXR3.bak"
      }
  },
deploy_configuration:
  %{
    Lips:
      %{
        "BuildLocation" => "//MOW04DEV014/Drop/Lips",
        "MsBuildDir" => "C:/Program Files/(x86)/MSBuild/12.0/Bin",
        "CompileAll" => true,
        "CompileCil" => true,
        "UninstallOnly" => false,
        "TFSIntegration" => true,
        "TFSURL" => "https://mediamarkt.visualstudio.com/defaultcollection",
        "TFSWorkspace" => "$LIPS/LIPS",
        "NoCleanOnError" => true,
        "InstallModelStore" => true,
        "SystemName" => "LIPS"
        },
    Fax:
      %{
        "BuildLocation" => "//MOW04DEV014/Drop/Fax",
        "MsBuildDir" => "C:/Program Files/(x86)/MSBuild/12.0/Bin",
        "CompileAll" => true,
        "CompileCil" => true,
        "UninstallOnly" => false,
        "TFSIntegration" => true,
        "TFSURL" => "https://mediamarkt.visualstudio.com/defaultcollection",
        "TFSWorkspace" => "$FAX/FAX",
        "NoCleanOnError" => true,
        "InstallModelStore" => true,
        "SystemName" => "FAX"
        },
      Wax:
        %{
          "BuildLocation" => "//MOW04DEV014/Drop/Wax",
          "MsBuildDir" => "C:/Program Files/(x86)/MSBuild/12.0/Bin",
          "CompileAll" => true,
          "CompileCil" => true,
          "UninstallOnly" => false,
          "TFSIntegration" => true,
          "TFSURL" => "https://mediamarkt.visualstudio.com/defaultcollection",
          "TFSWorkspace" => "$WAX/WAX",
          "NoCleanOnError" => true,
          "InstallModelStore" => true,
          "SystemName" => "WAX"
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
