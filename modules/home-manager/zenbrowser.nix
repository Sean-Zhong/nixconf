{ pkgs, inputs, ... }:
let
  lock-false = {
    Value = false;
    Status = "locked";
  };
  lock-true = {
    Value = true;
    Status = "locked";
  };
in
{
  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  programs.zen-browser = {
    enable = true;

    nativeMessagingHosts = [pkgs.firefoxpwa];

    policies = {
      AutofillAddressEnabled = true;
      AutofillCreditCardEnabled = false;
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = true;
      OfferToSaveLoginsDefault = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
    };

    profiles.sean.settings = {
      "zen.view.grey-out-inactive-windows" = lock-false;
      "zen.view.experimental-no-window-controls" = lock-true;
      "toolkit.legacyUserProfileCustomizations.stylesheets" = lock-true;
    };
  };

  home.file = {
    ".zen/sean/chrome/userChrome.css".source = ../../dotfiles/zen/userChrome.css;
    ".zen/sean/chrome/userContent.css".source = ../../dotfiles/zen/userContent.css;
    ".zen/sean/chrome/zen-logo-macchiato.svg".source = ../../dotfiles/zen/zen-logo-macchiato.svg;
  };
}

