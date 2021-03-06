#
# Copyright:: Copyright (c) 2013 Craig Tracey <craigtracey@gmail.com>
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'omnibus'
require 'omnibus-openstack/cli/base'
require 'pathname'

module OmnibusOpenstack
  module CLI
    class Build < Base

      DEFAULT_OVERRIDES_FILE = "openstack-config.json"

      DEFAULT_PROJECTS = [
        'keystone',
        'glance',
        'nova'
      ]

      namespace :default

      desc "build", "Build us some OpenStack"
      class_option :include,
        :aliases => [:i],
        :type => :string,
        :desc => "Comma delimited list of OpenStack components to include"
      class_option :exclude,
        :aliases => [:e],
        :type => :string,
        :desc => "Comma delimited list of OpenStack components to exclude"
      class_option :manifest,
        :aliases => [:m],
        :type => :string,
        :default => nil,
        :desc => "Manifest file to use"
      def build()
        include_projects = self.parse_options_list(options[:include]) || DEFAULT_PROJECTS
        exclude_projects = self.parse_options_list(options[:exclude]) || []

        intersect_projects = include_projects & exclude_projects
        if !intersect_projects.empty?
          say("You have specified #{intersect_projects.join(', ')} in both included and excluded projects.")
        end

        include_projects -= exclude_projects
        include_projects.unshift 'common'

        say("Let's start building #{include_projects}", :green)

        Omnibus::Config.override_file = options[:config] || DEFAULT_OVERRIDES_FILE
        Omnibus::Config.project_root = project_root
        Omnibus.configure

        include_projects.each { |project|
          proj = Omnibus.project("openstack-#{project}")
          proj.build_version('1.2.3')
          Rake::Task["projects:openstack-#{project}"].invoke
        }
      end
      default_task "build"

      no_commands {
        def parse_options_list(list)
          if list and !list.empty?
            list.split(',').map(&:strip)
          else
            nil
          end
        end

        def project_root()
          if spec = Gem::Specification.find_all_by_name('omnibus-openstack').first
            Pathname.new(spec.gem_dir)
          else
            Dir.getwd
          end
        end
      }

    end
  end
end
