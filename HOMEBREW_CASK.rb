# Initial cask template for mrdemonwolf/homebrew-den
# Copy this file to Casks/howlalert.rb in the homebrew-den repo.

cask "howlalert" do
  version "0.1.0"
  sha256 "PLACEHOLDER_FIRST_RELEASE_WILL_FILL"
  url "https://github.com/mrdemonwolf/howlalert/releases/download/v#{version}/HowlAlert.dmg"
  name "HowlAlert"
  desc "Claude Code usage monitor for Mac, iPhone, and Apple Watch"
  homepage "https://mrdemonwolf.github.io/howlalert/"
  livecheck do
    url :url
    strategy :github_latest
  end
  depends_on macos: ">= :sequoia", arch: :arm64
  app "HowlAlert.app"
  zap trash: [
    "~/Library/Application Support/HowlAlert",
    "~/Library/Preferences/com.mrdemonwolf.howlalert.mac.plist",
    "~/Library/Caches/com.mrdemonwolf.howlalert.mac",
  ]
end
