"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.TableModel = exports.TableSchema = void 0;
const mongoose_1 = __importDefault(require("mongoose"));
// Table Schema (just a name)
exports.TableSchema = new mongoose_1.default.Schema({
    table: { type: String },
});
exports.TableModel = mongoose_1.default.model('Table', exports.TableSchema);
