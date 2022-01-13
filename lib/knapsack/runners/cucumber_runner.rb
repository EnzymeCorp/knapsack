require "open3"
module Knapsack
  module Runners
    class CucumberRunner
      def self.run(args)
        grepped, _ = ::Open3.capture2("grep -iRn \"Scenario:\" features")

        all_scenarios = grepped.split("\n").map { |l| l.split(":")[0..1].map { |s| s.delete(" ")}.join(":") }

        allocator = Knapsack::AllocatorBuilder.new(Knapsack::Adapters::CucumberAdapter, all_tests: all_scenarios).allocator

        Knapsack.logger.info
        Knapsack.logger.info 'Report features:'
        Knapsack.logger.info allocator.report_node_tests
        Knapsack.logger.info
        Knapsack.logger.info 'Leftover features:'
        Knapsack.logger.info allocator.leftover_node_tests
        Knapsack.logger.info

        cmd = %Q[bundle exec cucumber #{args} --require #{allocator.test_dir} -- #{allocator.stringify_node_tests}]

        system(cmd)
        exit($?.exitstatus) unless $?.exitstatus == 0
      end
    end
  end
end
