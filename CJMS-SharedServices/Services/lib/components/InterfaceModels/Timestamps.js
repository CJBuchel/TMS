"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.initITimestamp = void 0;
function initITimestamp(instance) {
    const defaults = {
        createdAt: new Date(),
        updatedAt: new Date()
    };
    return {
        ...defaults,
        ...instance
    };
}
exports.initITimestamp = initITimestamp;
