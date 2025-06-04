import { Controller } from "@hotwired/stimulus"
import * as d3 from "d3"
import consumer from "../channels/consumer"

export default class extends Controller {
  static targets = ["chart"]

  connect() {
    this.setupChart()
    this.subscribeToChannel()
    window.addEventListener("resize", this.resizeChart.bind(this))
  }

  disconnect() {
    if (this.subscription) this.subscription.unsubscribe()
    window.removeEventListener("resize", this.resizeChart.bind(this))
  }

  setupChart() {
    this.margin = { top: 20, right: 20, bottom: 30, left: 40 }
    this.svg = d3.select(this.chartTarget).append("svg")
      .attr("preserveAspectRatio", "xMinYMin meet")
      .attr("width", "100%")
      .attr("height", "100%")
      .append("g")
      .attr("class", "chart-group")

    this.resizeChart()
  }

  resizeChart() {
    const containerWidth = this.chartTarget.clientWidth
    const containerHeight = this.chartTarget.clientHeight

    this.viewboxWidth = containerWidth
    this.viewboxHeight = containerHeight
    this.width = this.viewboxWidth - this.margin.left - this.margin.right
    this.height = this.viewboxHeight - this.margin.top - this.margin.bottom

    d3.select(this.chartTarget).select("svg")
      .attr("viewBox", `0 0 ${this.viewboxWidth} ${this.viewboxHeight}`)

    this.svgGroup = d3.select(this.chartTarget).select(".chart-group")
      .attr("transform", `translate(${this.margin.left},${this.margin.top})`)

    this.x = d3.scaleBand().range([0, this.width]).padding(0.1)
    this.y = d3.scaleLinear().range([this.height, 0])

    if (this.data) {
      this.updateChart(this.data)
    }
  }

  subscribeToChannel() {
    this.subscription = consumer.subscriptions.create("VotesChannel", {
      received: (data) => {
        this.handleData(data)
      }
    })
  }

  handleData(incoming) {
    this.data = incoming.map(d => {
      const existing = this.data?.find(e => e.label === d.label)
      return {
        ...d,
        oldValue: existing ? existing.value : 0
      }
    })
    this.updateChart(this.data)
  }

  updateChart(data) {
    this.x.domain(data.map(d => d.label))
    this.y.domain([0, d3.max(data, d => d.value)])

    const bars = this.svgGroup.selectAll(".bar").data(data, d => d.label)

    bars.enter()
      .append("rect")
      .attr("class", "bar")
      .attr("fill", d => d.color)
      .attr("x", d => this.x(d.label))
      .attr("width", this.x.bandwidth())
      .attr("y", this.height)
      .attr("height", 0)
      .merge(bars)
      .transition()
      .duration(800)
      .attr("x", d => this.x(d.label))
      .attr("width", this.x.bandwidth())
      .attr("y", d => this.y(d.value))
      .attr("height", d => this.height - this.y(d.value))

    bars.exit().transition().duration(500).attr("height", 0).remove()

    const amounts = this.svgGroup.selectAll(".amount").data(data, d => d.label)

    amounts.enter()
      .append("text")
      .attr("class", "amount")
      .attr("fill", d => d.color)
      .attr("x", d => this.x(d.label) + this.x.bandwidth() / 2)
      .attr("y", this.height - 65)
      .merge(amounts)
      .transition()
      .duration(800)
      .attr("x", d => this.x(d.label) + this.x.bandwidth() / 2)
      .attr("y", d => this.y(d.value) - 5)
      .tween("text", function (d) {
        const that = d3.select(this)
        const i = d3.interpolateNumber(d.oldValue, d.value)
        const format = d3.format(",d")
        return function (t) {
          that.text(format(i(t)))
        }
      })

    amounts.exit().remove()
  }
}
