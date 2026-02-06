export class Phone {
    constructor(brand = "CELLTOWA") {
        this.brand = brand;
        this.current_screen = 'home';
        this.menu_selected = 0;
        this.menu_items = [];
        this.is_message = false;
        this.is_sending = false;
        this.screen_text = '';  
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
        this.screen_renderers = {
            home: () => this.render_home(),
            text: () => this.render_text(),
            menu: () => this.render_menu(),
            confirm: () => this.render_confirm(),
        };
        this.key_handlers = {
            menu: (k) => this.handle_keys(k),
            confirm: (k) => this.handle_confirm(k),
        };
        this.build();
        this.attach_events();
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
                <div class="screen_content" id="screen_content">${this.render_screen()}</div>
            </div>
        `;
    }

    render_screen() {
        const renderer = this.screen_renderers[this.current_screen];
        return renderer ? renderer() : this.screen_renderers.home();
    }

    render_home() {
        return `<div class="screen_wrapper"><pre>       
──▄────▄▄▄▄▄▄▄────▄───
─▀▀▄─▄█████████▄─▄▀▀──
─────██─▀███▀─██──────
───▄─▀████▀████▀─▄────
─▀█────██▀█▀██────█▀──



</pre></div>`;
    }

    render_text() {
        if (!this.is_message) { return `<div class="screen_wrapper"><div class="text_display">${this.screen_text}</div></div>`; }
        return this.render_message()
    }

    render_message() {
        return `
            <div class="screen_wrapper">
                <div class="text_header"><i class="fa-solid fa-envelope"></i> MESSAGES</div>
                <div class="text_display">${this.screen_text}</div>
                <div class="text_footer">${this.is_sending ? "SEND" : "REPLY"}</div>
            </div>
        `;
    }

    render_menu() {
        return `
            <div class="screen_wrapper">
                <div class="menu_title">SELECT</div>
                <div class="menu_list">
                    ${this.menu_items.map((item, idx) => `
                        <div class="menu_item ${idx === this.menu_selected ? 'active' : ''}">
                            <span class="menu_name" title="${item.name}">${item.name}</span>
                        </div>
                    `).join('')}
                </div>
            </div>
        `;
    }

    render_confirm() {
        const selected = this.menu_items[this.menu_selected];
        return `
            <div class="screen_wrapper">
                <div class="menu_title">${selected.name}</div>
                <div class="confirm_info">
                    <div class="info_row">
                        <span>Qty:</span>
                        <span>${selected.quantity}</span>
                    </div>
                    <div class="info_row">
                        <span>Price:</span>
                        <span>$${selected.price}</span>
                    </div>
                </div>
            </div>
        `;
    }

    handle_keys(key) {
        if (key === 'up') {
            this.menu_selected = Math.max(0, this.menu_selected - 1);
            this.scroll_to_selected();
        } else if (key === 'down') {
            this.menu_selected = Math.min(this.menu_items.length - 1, this.menu_selected + 1);
            this.scroll_to_selected();
        } else if (key === 'call') {
            this.current_screen = 'confirm';
            this.update_screen();
        } else if (key === 'hang') {
            this.set_screen('home');
        }
    }

    handle_confirm(key) {
        if (key === 'call') {
            const selected = this.menu_items[this.menu_selected];
            $.post(`https://${GetParentResourceName()}/nui:confirm_order`, JSON.stringify({ item_id: selected.id }));
        } else if (key === 'hang') {
            this.current_screen = 'menu';
            this.update_screen();
        }
    }

    scroll_to_selected() {
        this.update_screen();
        setTimeout(() => {
            const selected = document.querySelector('.menu_item.active');
            if (selected) {
                selected.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
            }
        }, 0);
    }

    set_screen(name) {
        this.current_screen = name;
        this.update_screen();
    }

    set_text(text, is_message, send) {
        this.screen_text = '';
        this.is_message = is_message || false;
        this.is_sending = send || false;
        this.current_screen = 'text';
        this.update_screen();
        this.typewriter_text(text);
    }

    typewriter_text(text, speed = 30) {
        let index = 0;
        const type = () => {
            if (index < text.length) {
                this.screen_text += text[index];
                index++;
                this.update_screen();
                setTimeout(type, speed);
            }
        };
        type();
    }

    set_menu(items) {
        this.menu_items = items;
        this.menu_selected = 0;
        this.current_screen = 'menu';
        this.update_screen();
    }

    get_selected() {
        return this.menu_items[this.menu_selected];
    }

    update_screen() {
        $('#screen_content').html(this.render_screen());
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

    attach_events() {
        $(document).on('click', '.key', (e) => {
            const key = $(e.currentTarget).data('key');
            const handler = this.key_handlers[this.current_screen];
            if (handler) handler(key);
        });
        $(document).on('keyup', (e) => e.key === 'Escape' && this.close());
    }

    close() {
        this.current_screen = 'home';
        this.menu_selected = 0;
        this.menu_items = [];
        this.screen_text = '';
        this.is_message = false;
        this.is_sending = false;
        $(document).off('click', '.key');
        $(document).off('keyup');
        $("#app").empty();
        $.post(`https://${GetParentResourceName()}/nui:close_burner`);
    }
}