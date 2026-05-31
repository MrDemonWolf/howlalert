# Canonical source for the HowlAlert Homebrew cask.
#
# This file is the seed for `Casks/howlalert.rb` in the tap repo
# `mrdemonwolf/homebrew-den`. Copy it there ONCE (first release); after that
# the `update_homebrew.yml` workflow bumps `version` + `sha256` via PR on every
# published GitHub Release.
#
# Sparkle is disabled for Homebrew installs (the app detects its install path),
# so `brew upgrade` is the update path here — no `auto_updates true`.
cask "howlalert" do
  version "0.1.0"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"

  url "https://github.com/MrDemonWolf/howlalert/releases/download/v#{version}/HowlAlert-#{version}.dmg",
      verified: "github.com/MrDemonWolf/howlalert/"
  name "HowlAlert"
  desc "Claude Code usage-limit monitor for the Apple ecosystem"
  homepage "https://github.com/mrdemonwolf/howlalert"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: ">= :tahoe"

  app "HowlAlert.app"

  zap trash: [
    "~/Library/Application Support/com.mrdemonwolf.howlalert.mac",
    "~/Library/Caches/com.mrdemonwolf.howlalert.mac",
    "~/Library/Preferences/com.mrdemonwolf.howlalert.mac.plist",
    "~/Library/HTTPStorages/com.mrdemonwolf.howlalert.mac",
  ]
end
