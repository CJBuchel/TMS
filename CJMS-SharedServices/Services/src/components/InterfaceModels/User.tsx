export interface IUser {
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