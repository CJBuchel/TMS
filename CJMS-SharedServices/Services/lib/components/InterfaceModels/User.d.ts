import { ITimestamps } from "./Timestamps";
export interface IUser extends ITimestamps {
    username: string;
    password: string;
}
export declare function initIUser(instance?: IUser): {
    username: string;
    password: string;
    createdAt?: Date;
    updatedAt?: Date;
};
