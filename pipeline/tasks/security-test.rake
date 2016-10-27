#!/usr/bin/env ruby

require 'cfn_nag'

namespace :commit do
  desc 'Static security tests'
  task security_test: [:'commit:cfn_nag:app', :'commit:cfn_nag:jenkins']

  desc 'Execute CFN NAG tests against application'
  task :'cfn_nag:app' do
    template_path = 'provisioning/cloudformation/deployment.template'
    failures = CfnNag.new.audit(input_json_path: File.open(template_path),
                                output_format: 'txt')
    raise "CFN Nag found #{failures.to_i} issue(s)." if failures > 0
  end

  desc 'Execute CFN NAG tests against jenkins'
  task :'cfn_nag:jenkins' do
    template_path = 'provisioning/cloudformation/jenkins.template'
    failures = CfnNag.new.audit(input_json_path: File.open(template_path),
                                output_format: 'txt')
    raise "CFN Nag found #{failures.to_i} issue(s)." if failures > 0
  end
end

namespace :acceptance do
  desc 'Integration security tests'
  task security_test: [:'acceptance:inspector']

  task :inspector do
    system 'git', 'clone', 'https://github.com/stelligent/inspector-status'
    Dir.chdir('inspector-status') do
      system 'bundle', 'install'
      system './inspector.rb', '--target-tags', 'InspectorAuditable:true',
             '--aws-name-prefix', 'AWS-DEVSECOPS-WORKSHOP',
             '--rules-to-run', 'SEC,COM,RUN,CIS'
    end
  end
end

namespace :capacity do
  desc 'Penetration security tests'
  task :security_test do
    puts 'Security / Penetration testing against application'
  end
end
