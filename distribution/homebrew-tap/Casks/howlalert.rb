cask "howlalert" do
  version "__VERSION__"
  sha256 "__SHA256__"

  url "https://github.com/mrdemonwolf/howlalert/releases/download/v#{version}/HowlAlert-#{version}.dmg",
      verified: "github.com/mrdemonwolf/howlalert"
  name "HowlAlert"
  desc "Claude Code usage limit watcher for macOS"
  homepage "https://github.com/mrdemonwolf/howlalert"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on macos: ">= :tahoe"

  app "HowlAlert.app"

  zap trash: [
    "~/Library/Application Support/HowlAlert",
    "~/Library/Caches/com.mrdemonwolf.howlalert.mac",
    "~/Library/Preferences/com.mrdemonwolf.howlalert.mac.plist",
    "~/Library/Group Containers/group.com.mrdemonwolf.howlalert",
  ]
end
