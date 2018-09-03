
DEFAULT_CLIENT = Elasticsearch::Client.new host: ENV['ELASTICSEARCH_URL'] || 'localhost:9200'
$artist_repository = ArtistRepository.new(client: DEFAULT_CLIENT)
$album_repository = AlbumRepository.new(client: DEFAULT_CLIENT)

if Rails.env.development?
  logger           = ActiveSupport::Logger.new(STDERR)
  logger.level     = Logger::INFO
  logger.formatter = proc { |s, d, p, m| "\e[2m#{m}\n\e[0m" }
  DEFAULT_CLIENT.transport.logger = logger
end
