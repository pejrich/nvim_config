" This is needed otherwise Treesitter hides link text in vimdoc
call timer_start(200, { tid -> execute('TSBufDisable highlight')})
