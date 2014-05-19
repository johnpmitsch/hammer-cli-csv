# Copyright 2013-2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'hammer_cli'
require 'hammer_cli_csv'
require 'hammer_cli_foreman'
require 'hammer_cli_katello'
require 'json'
require 'csv'
require 'uri'

module HammerCLICsv
  class CsvCommand
    class ImportCommand < HammerCLI::Apipie::Command
      command_name 'import'
      desc         'import by directory'

      option %w(-v --verbose), :flag, 'be verbose'
      option %w(--server), 'SERVER', 'Server URL'
      option %w(-u --username), 'USERNAME', 'Username to access server'
      option %w(-p --password), 'PASSWORD', 'Password to access server'
      option '--dir', 'DIRECTORY', 'directory to import from'
      option '--roles', 'FILE', 'source to import roles'
      option '--users', 'FILE', 'source to import users'
      option '--hosts', 'FILE', 'source to import hosts'
      option '--organizations', 'FILE', 'source to import organizations'

      def ctx
        {
          :interactive => false,
          :username => 'admin',
          :password => 'changeme'
        }
      end

      def hammer(context = nil)
        HammerCLI::MainCommand.new('', context || ctx)
      end

      def execute
        @api = ApipieBindings::API.new({
                                         :uri => option_server || HammerCLI::Settings.get(:csv, :host),
                                         :username => option_username || HammerCLI::Settings.get(:csv, :username),
                                         :password => option_password || HammerCLI::Settings.get(:csv, :password),
                                         :api_version => 2
                                       })

        # Swing the hammers
        swing('organizations')
        swing('roles')
        swing('users')
        swing('hosts')

        HammerCLI::EX_OK
      end

      def swing(resource)
        options_file = self.send("option_#{resource}")
        options_file ||= "#{option_dir}/#{resource}.csv" if option_dir
        args = %W{ csv #{resource} --csv-file #{options_file} }
        args << '-v' if option_verbose?
        hammer.run(args) if File.exists? options_file
      end
    end
  end
end
