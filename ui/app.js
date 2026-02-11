import { Phone } from "./js/Phone.js";

/**
 * Registered message handlers for NUI callbacks.
 * @type {Object<string, Function>}
 */
const handlers = {};

let phone;

/**
 * Initialize phone when NUI is ready
 */
handlers.build = (data) => {
    phone = new Phone(data.brand);
};

/**
 * Set phone text with typewriter effect
 */
handlers.set_text = (data) => {
    phone.set_text(data.text, data.is_message || false, data.send || false);
};

/**
 * Set phone menu
 */
handlers.set_menu = (data) => {
    phone.set_menu(data.items, data.rep_level);
};

/**
 * Set phone screen
 */
handlers.set_screen = (data) => {
    phone.set_screen(data.screen);
};

/**
 * Close phone
 */
handlers.close_phone = () => {
    phone.close();
};

/**
 * Global message listener for all NUI messages.
 */
window.addEventListener("message", (event) => {
    const { func } = event.data;
    const handler = handlers[func];

    if (typeof handler !== "function") {
        console.warn(`Handler missing: ${func}`);
        return;
    }

    handler(event.data);
});


/**
 * Test stuff - uncomment to test UI in browser
 */
/*
handlers.build({ brand: "CELLTOWA" });
handlers.set_text({ text: "Yo got supply in?", is_message: true, send: true });

window.test_text = () => {
    phone.set_text("Yo got supply in?");
};

window.test_menu = () => {
    phone.set_menu([
        { id: 'weed', name: 'Weed', price: 100, quantity: 10 },
        { id: 'coke', name: 'Coke', price: 250, quantity: 2 },
        { id: 'heroin', name: 'Heroin', price: 500, quantity: 3 },
        { id: 'mdma', name: 'MDMA', price: 175, quantity: 5 },
        { id: 'meth', name: 'Meth', price: 300, quantity: 1 },
        { id: 'meth2', name: 'Meth2', price: 300, quantity: 1 },
        { id: 'meth3', name: 'Meth3', price: 300, quantity: 1 },
    ]);
};

window.test_unavailable = () => {
    phone.set_text("NAH MAN COPS EVERYWHERE");
};

window.test_home = () => {
    phone.set_screen('home');
};
*/