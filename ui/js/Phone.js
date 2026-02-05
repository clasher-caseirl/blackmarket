export class Phone {
    constructor(brand = "CELLTOWA") {
        this.brand = brand;
        this.soft_keys = [
            { key: 'call', label: '<i class="fa-solid fa-phone"></i>', class: 'call_btn' },
            { key: 'hang', label: '<i class="fa-solid fa-phone-slash"></i>', class: 'hang_btn' },
        ];
        this.nav_keys = [
            { key: 'up', label: '<i class="fa-solid fa-chevron-up"></i>', class: 'nav_btn up_btn' },
            { key: 'down', label: '<i class="fa-solid fa-chevron-down"></i>', class: 'nav_btn down_btn' },
        ];
        this.key_map = [
            { key: '1', label: '&#9903' },
            { key: '2', label: 'ABC' },
            { key: '3', label: 'DEF' },
            { key: '4', label: 'GHI' },
            { key: '5', label: 'JKL' },
            { key: '6', label: 'MNO' },
            { key: '7', label: 'PQRS' },
            { key: '8', label: 'TUV' },
            { key: '9', label: 'WXYZ' },
            { key: '*', label: '' },
            { key: '0', label: '+' },
            { key: '#', label: '' },
        ];
        this.ascii = `<pre>       
──▄────▄▄▄▄▄▄▄────▄───
─▀▀▄─▄█████████▄─▄▀▀──
─────██─▀███▀─██──────
───▄─▀████▀████▀─▄────
─▀█────██▀█▀██────█▀──



</pre>`;
        this.current_screen = "boii_dev";
        this.build();
    }

    build() {
        $("#app").html(`
            <div class="phone_container">
                <div class="screen_container">
                    ${this.build_header()}
                    ${this.build_screen()}
                </div>
                ${this.build_soft_keys()}
                ${this.build_keypad()}
                ${this.build_footer()}
            </div>
        `);
    }

    build_header() {
        return `
            <div class="phone_header">
                <div class="top_speaker"></div>
                <div class="brand">${this.brand}</div>
            </div>
        `;
    }

    build_screen() {
        return `
            <div class="screen">
                ${this.build_signal_bars()}
                ${this.build_battery_bars()}
                <div class="screen_content" id="screen_content">${this.ascii}</div>
            </div>
        `;
    }

    build_signal_bars() {
        return `
            <div class="signal_bars">
                ${Array(5).fill('<div class="signal_bar"></div>').join('')}
                <div class="signal_icon"><i class="fa-solid fa-tower-broadcast"></i></div>
            </div>
        `;
    }

    build_battery_bars() {
        return `
            <div class="battery_bars">
                ${Array(5).fill('<div class="battery_bar"></div>').join('')}
                <div class="battery_icon"><i class="fa-solid fa-battery-full fa-rotate-270"></i></div>
            </div>
        `;
    }

    build_soft_keys() {
        return `
            <div class="soft_keys">
                <button class="key ${this.soft_keys[0].class}" data-key="${this.soft_keys[0].key}">
                    ${this.soft_keys[0].label}
                </button>
                <div class="nav_wrap">
                    ${this.nav_keys.map(k => `
                        <button class="key ${k.class}" data-key="${k.key}">
                            ${k.label}
                        </button>
                    `).join('')}
                </div>
                <button class="key ${this.soft_keys[1].class}" data-key="${this.soft_keys[1].key}">
                    ${this.soft_keys[1].label}
                </button>
            </div>
        `;
    }

    build_keypad() {
        return `
            <div class="keypad">
                ${this.key_map.map(k => `
                    <button class="key" data-key="${k.key}">
                        ${k.key}
                        ${k.label ? `<span class="letters">${k.label}</span>` : ''}
                    </button>
                `).join('')}
            </div>
        `;
    }

    build_footer() {
        return `
            <div class="footer">
                <div class="btm_speaker"></div>
            </div>
        `;
    }
}