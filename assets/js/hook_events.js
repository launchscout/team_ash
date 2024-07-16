const EventsHook = {
  mounted() {
    console.debug('mounted', this.el);
    this.el.dispatchEvent(new CustomEvent("phx:mounted", {detail: this}));
  },

  beforeUpdate() {
    console.debug('beforeUpdate', this.el);
    this.el.dispatchEvent(new CustomEvent("phx:before-update", {detail: this}));
  },

  updated() {
    console.debug('updated', this.el);
    this.el.dispatchEvent(new CustomEvent("phx:updated", {detail: this, bubbles: true}));
  },

  destroyed() {
    console.debug('destroyed', this.el);
    this.el.dispatchEvent(new CustomEvent("phx:destroyed", {detail: this}));
  },

  disconnected() {
    console.debug('disconnected', this.el);
    this.el.dispatchEvent(new CustomEvent("phx:disconnected", {detail: this}));
  },

  reconnected() {
    console.debug('reconnected', this.el);
    this.el.dispatchEvent(new CustomEvent("phx:reconnected", {detail: this}));
  }
}

export default EventsHook;