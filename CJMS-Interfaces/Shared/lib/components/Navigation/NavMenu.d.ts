import { Component } from "react";
import "../../assets/stylesheets/NavMenu.scss";
export interface NavMenuLink {
    name: string;
    path: string;
    linkTo: any;
}
export interface NavMenuCategory {
    name: string;
    links: Array<NavMenuLink>;
}
export interface NavMenuContent {
    navCategories: Array<NavMenuCategory>;
}
interface IProps {
    navContent: NavMenuContent;
}
interface IState {
    external_eventData: any;
    eventState: string;
}
export default class NavMenu extends Component<IProps, IState> {
    constructor(props: any);
    setEventState(stateData: any): void;
    setEventData(eventData: any): void;
    componentDidMount(): Promise<void>;
    getRoute(link: NavMenuLink): JSX.Element;
    clearSessionStorage(): void;
    getRoutes(): JSX.Element;
    getContent(): JSX.Element;
    getState(): JSX.Element;
    getMode(): JSX.Element;
    render(): JSX.Element;
}
export {};
