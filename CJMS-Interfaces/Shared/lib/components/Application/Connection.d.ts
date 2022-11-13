import { Component } from "react";
import "../../assets/stylesheets/ConnectionModal.scss";
interface IProps {
    app: any;
}
interface IState {
    isOnline: boolean;
    retryCount: number;
    loop?: any;
}
export declare class ConnectionCheck extends Component<IProps, IState> {
    constructor(props: any);
    componentDidMount(): Promise<void>;
    componentWillUnmount(): void;
    connectionCheck(): void;
    startLoop(): void;
    render(): any;
}
export {};
