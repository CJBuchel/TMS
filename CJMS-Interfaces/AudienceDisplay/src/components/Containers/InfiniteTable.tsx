import React, { Component, useRef } from 'react'
import "../../assets/application.scss";
import "../../assets/InfiniteTable.scss";

const DEFAULT_SPEED = 1;
const DEFAULT_DELAY = 1000;

interface IProps {}

interface IState {
  scrollTop:number;
  table_body:any;
}

export default class InfiniteTable extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      scrollTop: 0,
      table_body: React.createRef()
    }

    this.scrollCallback = this.scrollCallback.bind(this);
  }
  
  unmountScroll = false;

  scrollCallback() {
    if (!this.unmountScroll) {
      this.setState({scrollTop: this.newScroll(this.state.scrollTop)});
      window.requestAnimationFrame(() => this.scrollCallback());
    }
  }

  componentDidMount() {
    this.unmountScroll = false;
    setTimeout(() => window.requestAnimationFrame(() => this.scrollCallback()), DEFAULT_DELAY);
  }

  componentWillUnmount() {
    this.unmountScroll = true;
  }

  bodyScrollHeight() {
    return this.state.scrollTop + this.state.table_body.current?.scrollHeight || 0; // document.body.scrollHeight
  }
  
  isScrolling() {
    return window.innerHeight < this.bodyScrollHeight() ? true : false;
  }

  newScroll(oldScroll:number) {
    const height = this.bodyScrollHeight();
    // console.log("Height: " + height);
    // console.log("OldScroll: " + oldScroll);
    if (!this.isScrolling()) {
      return 0;
    } else if (oldScroll >= height/3) {
      console.log("Resetting");
      return (oldScroll - height/3);
    } else {
      // console.log("scrolling");
      return oldScroll + (DEFAULT_SPEED/2);
    }
  }

  getFormattedData() {
    const content:any[] = []
    for (var i = 0; i < 50; i++) {
      content.push(
        <tr key={i}>
          <td>{i}</td>
          <td>Yay</td>
          <td>Yay</td>
          <td>Yay</td>
          <td>Yay</td>
        </tr>
      );
    }

    return(
      content
    );
  }


  renderTable() {
    const firstTable = this.getFormattedData();
    const secondTable = this.getFormattedData();

    // const scrolling = Object.keys(this.refs).length ? this.isScrolling() : false;
    // const scrolling = this.isScrolling();

    // if (this.isScrolling())
    const scrolling = this.isScrolling();
    // const scrolling = this.isScrolling() == false ? false : true;

    if (scrolling) {
      return(
        <tbody id='table-body' ref={this.state.table_body}>
          {firstTable}
          {secondTable}
        </tbody>
      );
    } else {
      return(
        <tbody id='table-body' ref={this.state.table_body}>
          {firstTable}
        </tbody>
      );
    }
  }

  render() {
    return (
      <div id='table-wrapper' className='table-wrapper' style={{direction: 'ltr', marginTop: -this.state.scrollTop}}>
        <table id='table-parent' className='fl-table ui scrollable single line very basic compact table'>
          <thead id='table-head'>
            <tr>
              <th>Rank</th>
              <th>Team Name</th>
              <th>Round 1</th>
              <th>Round 2</th>
              <th>Round 3</th>
            </tr>
          </thead>
          { this.renderTable() }
        </table>
      </div>
    );
  }
} 