class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :prepare_meta_tags, if: "request.get?", only: :show

  def prepare_meta_tags(options={})
    set_meta_tags build_meta_options(options)
  end

  helper_method :voted?, :agreed?, :disagreed?
  def voted? opinion
    voted_opinions = JSON.parse(cookies[:voted_opinions_x] || "{}")
    voted_opinions.has_key? opinion.id.to_s
  end

  def agreed? opinion
    voted_opinions = JSON.parse(cookies[:voted_opinions_x] || "{}")
    voted_opinions.has_key?(opinion.id.to_s) and voted_opinions[opinion.id.to_s] == 'agree'
  end

  def disagreed? opinion
    voted_opinions = JSON.parse(cookies[:voted_opinions_x] || "{}")
    voted_opinions.has_key?(opinion.id.to_s) and voted_opinions[opinion.id.to_s] == 'disagree'
  end

  private

  def build_meta_options(options)
    unless options.nil?
      options.compact!
      options.reverse_merge! default_meta_options
    else
      options = default_meta_options
    end

    current_url = request.url
    og_description = (view_context.strip_tags options[:description]).truncate(160)

    {
      site:        options[:site_name],
      title:       options[:title],
      reverse:     true,
      image:       view_context.asset_url(options[:image]),
      description: options[:description],
      keywords:    options[:keywords],
      canonical:   current_url,
      twitter: {
        site_name: options[:site_name],
        site: '',
        card: 'summary',
        description: twitter_description(options),
        image: view_context.asset_url(options[:image])
      },
      og: {
        url: current_url,
        site_name: options[:site_name],
        title: options[:title],
        image: view_context.asset_url(options[:image]),
        description: og_description,
        type: 'website'
      }
    }
  end

  def default_meta_options
    {
      site_name: "국민의 편지",
      title: "국민의 편지",
      description: "국회의장에게 테러방지법과 필리버스터에 관한 국민의 세가지 의견을 전달합니다.",
      keywords: "테러방지법 필리버스터 국회",
      image: view_context.image_url("sns_vote.png")
    }
  end

  def twitter_description(options)
    limit = 140
    title = view_context.strip_tags options[:title]
    description = view_context.strip_tags options[:description]
    if title.length > limit
      title.truncate(limit)
    else
      description.truncate(limit)
    end
  end
end
