import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="datatable-index-charts"
export default class extends Controller {
  connect() {
    var self = this

    $(".effective-datatable").on("draw.dt", function(e, dt, type, indexes) {
      if (dt && dt.json && dt.json.charts) {
        var jsonCharts = dt.json.charts
        for (var chart in jsonCharts) {
          var chartkickChart = Chartkick.charts[chart]
          chartkickChart.updateData(self.transformData(jsonCharts[chart]))
          chartkickChart.redraw()
        }
      }
    });
  }

  transformData(chart) {
    var self = this
    if (chart.as == 'LineChart') {
      // we don't know what to do
      return chart.data
    } else {
      return chart.data
    }
  }
}
