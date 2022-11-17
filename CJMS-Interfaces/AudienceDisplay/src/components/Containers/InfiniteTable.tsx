import React, { Component, useRef } from 'react'
import "../../assets/stylesheets/application.scss";
import "../../assets/stylesheets/InfiniteTable.scss";

const DEFAULT_SPEED = 0.5;
const DEFAULT_DELAY = 1000;
const LOOP_FREQUENCY = 200;
interface IProps {
  headers:any;
  data:any;
}

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
  frameCount = 0;
  fps = LOOP_FREQUENCY;
  fpsInterval = 0;
  startTime = 0;
  now = 0;
  then = 0;
  elapsed = 0;

  scrollCallback() {
    if (this.unmountScroll) {
      return;
    }

    window.requestAnimationFrame(this.scrollCallback);

    this.now = Date.now();
    this.elapsed = this.now - this.then;
    if (this.elapsed > this.fpsInterval) {
      this.then = this.now - (this.elapsed % this.fpsInterval);
      this.setState({scrollTop: this.newScroll(this.state.scrollTop)});
    }
  }

  startAnimation() {
    this.fpsInterval = 1000/this.fps;
    this.then = Date.now();
    this.startTime = this.then;
    // console.log(this.startTime);
    this.scrollCallback();
  }

  componentDidMount() {
    this.unmountScroll = false;
    setTimeout(() => this.startAnimation(), DEFAULT_DELAY);
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

    if (!this.isScrolling()) {
      return 0;
    } else if (oldScroll >= height/3) {
      // console.log("Resetting");
      return (oldScroll - height/3);
    } else {
      // console.log("scrolling");
      return oldScroll + DEFAULT_SPEED; //Math.ceil(DEFAULT_SPEED/3)
    }
  }

  getFormattedData(data:any[]) {
    const content:any[] = [];
    var numCols = 0;
    // console.log(data);
    for (const row of data) {
      const columns:any[] = [];
      numCols = 0;
      for (const column of Object.keys(row)) {
        columns.push(<td key={column}>{row[column]}</td>);
        numCols++;
      }

      content.push(
        <tr key={row[1]}>
          {columns}
        </tr>
      );
    }

    if (content.length % 2!=0) {
      // console.log('uneven, adding placeholder');
      const blank_row:any[] = [];
      for (var i = 0; i < numCols; i++) {
        blank_row.push(<td key={`blank_col_${i}`}>&nbsp;</td>)
      }

      content.push(
        <tr key={"blank_placeholder"}>
          {blank_row}
        </tr>
      );
    }

    return(
      content
    );
  }

  getFormatedHeaders(headers:any[]) {
    const content:any[] = [];
    for (const header of headers) {
      content.push(<th key={header}>{header}</th>);
    }

    return (<tr key={"headers"}>{content}</tr>);
  }

  renderTable() {
    // console.log('rendering table');
    const firstTable = this.getFormattedData(this.props.data);
    const secondTable = this.getFormattedData(this.props.data);

    const scrolling = this.isScrolling();

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
        <table id='table-parent' className='fl-table'>
          <thead id='table-head'>
            { this.getFormatedHeaders(this.props.headers) }
          </thead>
          { this.renderTable() }
        </table>
      </div>
    );
  }
}