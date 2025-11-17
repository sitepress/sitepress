## Example deployment script to an Amazon Web Servie S3 bucket.
s3_bucket_name = "<replace-with-your-bucket-name>"

desc "Remove all files from the build directory"
task :clean do
  sh 'rm -rf ./build'
end

desc "Compile the sitepress site"
task :compile do
  sh 'bundle exec sitepress compile'
end

namespace :publish do
  desc "Upload ./build/assets to S3 with cache-control headers optimized for assets"
  task :assets do
    sh "aws s3 sync ./build/assets s3://#{s3_bucket_name}/assets --cache-control max-age=31536000"
  end

  desc "Upload ./build to S3"
  task :pages do
    sh "aws s3 sync ./build s3://#{s3_bucket_name} --exclude 'assets/**' --cache-control max-age=60"
  end
end

desc "Upload pages and assets to S3"
task publish: %w[publish:assets publish:pages]

task default: %w[clean compile publish]
