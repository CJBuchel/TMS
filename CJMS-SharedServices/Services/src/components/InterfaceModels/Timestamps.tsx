export interface ITimestamps {
  createdAt?: Date;
  updatedAt?: Date;
}

export function initITimestamp(instance?:ITimestamps) {
  const defaults:ITimestamps = {
    createdAt: new Date(),
    updatedAt: new Date()
  }

  return {
    ...defaults,
    ...instance
  }
}