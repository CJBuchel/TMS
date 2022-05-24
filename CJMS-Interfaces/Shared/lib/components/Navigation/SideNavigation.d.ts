import { Component } from "react";
import "../../assets/stylesheets/SideNavigation.scss";
export interface NavContentLink {
    icon: any;
    name: string;
    path: string;
    linkTo: any;
}
export interface NavContent {
    background: string;
    title: string;
    links: Array<NavContentLink>;
}
interface IProps {
    navContent: NavContent;
}
interface IState {
    sidebarOpen: boolean;
    routes: any[];
}
export default class SideNavigation extends Component<IProps, IState> {
    constructor(props: any);
    onSetSidebar(open: boolean): void;
    getRoute(link: NavContentLink): JSX.Element;
    getRoutes(): JSX.Element;
    getContent(): JSX.Element;
    render(): JSX.Element;
}
export {};
