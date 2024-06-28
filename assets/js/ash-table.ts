import { LitElement, html, css } from "lit";
import { customElement } from 'lit/decorators.js';

@customElement('ash-table')
class AshTableElement extends LitElement {
  static styles = css`
    :host {
      display: table;
    }
  `;
}