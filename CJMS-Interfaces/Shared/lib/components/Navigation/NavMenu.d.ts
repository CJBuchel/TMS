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
}
export default class NavMenu extends Component<IProps, IState> {
    constructor(props: any);
    getRoute(link: NavMenuLink): JSX.Element;
    getRoutes(): JSX.Element;
    getContent(): JSX.Element;
    render(): JSX.Element;
}
export {};
