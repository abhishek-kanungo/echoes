class CrawlRun < ApplicationRecord
  enum :status, {
    running: "running",
    paused:  "paused",
    done:    "done",
    error:   "error"
  }, prefix: :status

  def next_page
    (current_page + 1)
  end

  def advance!(page:, total_pages:)
    update!(current_page: page, total_pages: (self.total_pages || total_pages))
    status_done! if current_page >= self.total_pages
  end
end
