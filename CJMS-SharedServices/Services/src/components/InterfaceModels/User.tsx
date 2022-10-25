import { ITimestamps } from "./Timestamps";

export interface IUser extends ITimestamps {
  username: string;
  password: string;
}

export function initIUser(instance?:IUser) {
  const defaults:IUser = {
    username: '',
    password: 'password'
  }

  return {
    ...defaults,
    ...instance
  }
}