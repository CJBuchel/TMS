"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.initIUser = void 0;
function initIUser(instance) {
    const defaults = {
        username: '',
        password: 'password'
    };
    return {
        ...defaults,
        ...instance
    };
}
exports.initIUser = initIUser;
