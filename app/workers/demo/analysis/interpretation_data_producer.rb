require 'redis'

module Workers
  module Demo
    module Analysis
      class InterpretationDataProducer
        include Sidekiq::Worker
        sidekiq_options retry: false

        def perform(friendlyResourceId, friendlyResourceIp)
          logger.info("InterpretationDataProducer - friendlyResourceId : #{friendlyResourceId}, friendlyResourceIp : #{friendlyResourceIp}")
          redisDosChannel = "#{friendlyResourceIp}_dosRawData"
          logger.debug("InterpretationDataProducer - redis channels : #{redisDosChannel}")
          redis = Redis.new(:host => 'localhost', :port => '6379', :timeout => 0)
          redis.subscribe(redisDosChannel) do |on|
            on.message do |channel, messageRaw|
              message = JSON.parse(messageRaw)
              if message['continueAnalysis']
                case channel
                when redisDosChannel
                  DosAnalysisSlave.perform_async(friendlyResourceId, message['intelligenceData'])
                else
                  logger.debug("InterpretationDataProducer - undefined channel : #{channel}")
                end
              else
                redis.unsubscribe(redisDosChannel)
                logger.debug("InterpretationDataProducer - unsubscribed from channels : #{redisDosChannel}")
              end
            end
          end
        end
        # Every slave will do some math and chage contents of db
        # Hopefully, slave is enough to minimize chances of deadlock or bad db update
        class DosAnalysisSlave
          include Sidekiq::Worker
          sidekiq_options retry: false, queue: 'analysis_slave'
        
          def perform(friendlyResourceId, intelligenceData)
            logger.info("DosAnalysisSlave - friendlyResourceId : #{friendlyResourceId}, intelligenceData : #{intelligenceData}")
          end
        end # DosAnalysisSlave
      end # InterpretationDataProducer
    end # Analysis
  end # Demo
end # Workers
