import React from "react";
interface IProps {
    setToken: any;
    allowedUser: any;
}
interface IState {
    username: String;
    password: String;
    userOptions: any;
}
export declare class Login extends React.Component<IProps, IState> {
    constructor(props: any);
    loginUser(credentials: any, allowedUser: any): Promise<false | RequestInfo>;
    handleSubmit: (e: any) => Promise<void>;
    onUserChange: (user: string) => void;
    render(): JSX.Element;
}
export {};
