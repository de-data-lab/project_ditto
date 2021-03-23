const launchIntroJs = function()
{introJs().setOptions({
  steps: [{
    title: 'Welcome 👋',
    intro: 'Have you ever wondered what other places in the country are experiencing the pandemic in the same way that you are?<br><br>One way to think about that is to ask "which counties have had the most similar case trends to my county?" Are there other counties in the country whose cases have risen and fallen in the same way that yours has?'
  },
  {
    element: document.querySelector('#county_select_row'),
    title: 'Select a County 👆',
    intro: 'You can select the county that you\'re curious about by selecting it from the dropdown. You can type the name of the county or scroll to find the county that you are interested in. Your selected county will be outlined in red on the map.',
    position: 'bottom'
  },
  {
    element: document.querySelector('#county_map_box'),
    title: 'Similarity Heatmap 🗺',
    intro: 'Once you select a county, the map will be updated automatically.<br><br>Counties that have had the most similar COVID-19 trends to yours will be more <span style="color: #FDE823; text-shadow: -1px -1px 0 #000, 1px -1px 0 #000, -1px 1px 0 #000, 1px 1px 0 #000;"><b>yellow</b></span>. <br><br>Counties that are least similar will be more <span style="color: #450D54"><b>purple</b></span>. You can pan and zoom as you need.',
    position: 'top'
  },
  {
    element: document.querySelector('#table_similarity_box'),
    title: 'Similarity Table 📶',
    intro: 'All US counties are indexed for similarity against your selection and displayed in the table by descending similarity score.<br><br>A similarity score of 100% means that the county has had identical spread to your selected county. We included some metadata about COVID-19 spread in each county to help give context too.',
    position: 'top'
  },
  {
    element: document.querySelector('#plotly_trend_box'),
    title: 'Cases per 100,000 Trended 📉',
    intro: 'Finally, you can see an overlay of your <span style="color: #E83536"><b>selected county (in red)</b></span> compared to the <span style="color: #9e9e9e;"><b>top 10 most similar counties (in light gray)</b></span> based upon COVID-19 cases per hundred thousand people. You can also see the raw count by toggling the button.',
    position: 'top'
  },
  {
    title: 'Share 🗣',
    intro: 'Interested in sharing the data for your county? Simply click the "Share" button and you\'ll be provided with a link to copy to pass along to friends and family.<br><br>Happy exploring! If you have any feedback drop a line to <a href=\'mailto:hello@ddil.ai\'>hello@ddil.ai</a> or on <a href=\'https://twitter.com/ddil_de\' target=\'_blank\'>Twitter at @DDIL_de</a>!'
  }
  ]
}).oncomplete(function() {
  localStorage.setItem('doneTour', 'yeah!');
}).onexit(function() {
   localStorage.setItem('doneTour', 'yeah!');
}).start();

if (window.innerWidth < 500) {
          document.querySelector('.introjs-tooltip').style.minWidth = "320px";
          document.querySelector('.introjs-tooltip').style.marginLeft = "-160px";
           }
};

if (localStorage.getItem('doneTour') !== 'yeah!'){
  launchIntroJs();
}