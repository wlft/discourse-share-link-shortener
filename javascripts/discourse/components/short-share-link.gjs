import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DToggleSwitch from "discourse/components/d-toggle-switch";
import { getAbsoluteURL } from "discourse/lib/get-url";
import { i18n } from "discourse-i18n";

export default class ShortShareLink extends Component {
  @service site;
  @service router;
  @service currentUser;

  @tracked isShortened = false;

  constructor() {
    super(...arguments);

    if (settings.remember_preference && this.prefersShort) {
      this.shortenLink();
    }
  }

  get prefersShort() {
    if (settings.remember_preference) {
      return localStorage.getItem("short-share-link");
    }
  }

  get absoluteDomain() {
    if (settings.shorter_domain != '') {
      return ((settings.shorter_domain.startsWith('https://') || settings.shorter_domain.startsWith('http://')) ? '' : 'https://') + settings.shorter_domain + (settings.shorter_domain.endsWith('/') ? '' : '/')
    };

    return getAbsoluteURL("/");
  }

  get topicId() {
    return this.args.topic.id;
  }

  get topicSlug() {
    return this.args.topic.slug;
  }

  get userSegment() {
    return this.currentUser ? `?u=${this.currentUser.username}` : "";
  }

  get postSegment() {
    return this.args.post?.post_number > 1
      ? `/${this.args.post.post_number}`
      : "";
  }

  get shareInput() {
    return document.getElementById("invite-link");
  }

  #changeValueandFocus(value) {
    this.shareInput.value = value;
    this.shareInput.focus();

    if (!this.site.mobileView) {
      this.shareInput.select();
    }
  }

  @action
  shortenLink() {
    const shortenedLink = `${this.absoluteDomain}t/${this.topicId}${this.postSegment}`;
    this.#changeValueandFocus(shortenedLink);

    this.isShortened = true;

    if (settings.remember_preference) {
      localStorage.setItem("short-share-link", true);
    }
  }

  @action
  lengthenLink() {
    const lengthenedLink = `${this.absoluteDomain}t/${this.topicSlug}/${this.topicId}${this.postSegment}${this.userSegment}`;
    this.#changeValueandFocus(lengthenedLink);

    this.isShortened = false;

    if (settings.remember_preference) {
      localStorage.removeItem("short-share-link");
    }
  }

  <template>
    <DToggleSwitch
      class="btn-link-length"
      @state={{this.isShortened}}
      @translatedLabel={{i18n (themePrefix "short_link_label")}}
      {{on
        "click"
        (if this.isShortened (action "lengthenLink") (action "shortenLink"))
      }}
    />
  </template>
}
