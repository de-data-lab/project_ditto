if (localStorage.getItem('doneTour') !== 'yeah!'){
  introJs().setOptions({
  steps: [{
    title: 'Welcome',
    intro: 'Hello World! 👋<br>Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?'
  },
  {
    element: document.querySelector('#county_select_row'),
    intro: 'This step focuses on an element',
    position: 'bottom'
  },
  {
    element: document.querySelector('#county_map_box'),
    intro: 'This is the county map',
    position: 'top'
  },
  {
    element: document.querySelector('#table_similarity_box'),
    intro: 'This is the table of similarity',
    position: 'top'
  },
  {
    element: document.querySelector('#plotly_trend_box'),
    intro: 'This is the trend',
    position: 'top'
  },
  {
    title: 'Thanks',
    intro: 'Good Bye! 👋'
  }
  ]
}).oncomplete(function() {
  localStorage.setItem('doneTour', 'yeah!');
}).onexit(function() {
   localStorage.setItem('doneTour', 'yeah!');
}).start()
};