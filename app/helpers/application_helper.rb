module ApplicationHelper
  def default_meta_tags
    {
      site: "okita!!",
      title: "一緒に起床を共有できるサービス",
      reverse: true,
      charset: "utf-8",
      description: "okita!!では、ユーザー同士が一緒に起床することで二度寝を防ぐためのアプリです",
      keywords: "起床,早起き,サービス",
      canonical: "https://okita-project.onrender.com/",
      separator: "|",
      og: {
        site_name: :site,
        title: :title,
        description: :description,
        type: "website",
        url: "https://okita-project.onrender.com/",
        image: image_url("static_ogp.jpg"),
        local: "ja-JP"
      },
      twitter: {
        card: "summary_large_image",
        site: "@obvyamdrss",
        image: image_url("static_ogp.jpg")
      }
    }
  end
end
