describe Solr4R::Client do

  describe '::query_string' do

    [
      [nil, nil],
      [nil, ''],
      [nil, []],
      [nil, {}],

      ['title:foo', 'title:foo'],
      ['title:foo%26bar', 'title:foo&bar'],
      ['title:foo&bar', 'title:foo&bar', false],

      ['title:foo author:bar', 'title:foo author:bar'],
      ['title:foo author:(bar baz)', 'title:foo author:(bar baz)'],
      ['title:foo -author:(bar baz)', 'title:foo -author:(bar baz)'],

      ['title:foo', %w[title:foo]],
      ['title:foo%26bar', %w[title:foo&bar]],
      ['title:foo&bar', %w[title:foo&bar], false],

      ['title:foo author:bar', %w[title:foo author:bar]],
      ['title:foo author:bar', ['title:foo', author: 'bar']],
      ['title:foo author:(bar baz)', %w[title:foo author:(bar\ baz)]],
      ['title:foo -author:(bar baz)', %w[title:foo -author:(bar\ baz)]],
      ['title:foo -author%26:(bar baz)', %w[title:foo -author&:(bar\ baz)]],
      ['title:foo -author&:(bar baz)', %w[title:foo -author&:(bar\ baz)], false],

      ['title:foo', title: 'foo'],
      ['title:foo%26bar', title: 'foo&bar'],
      ['title:foo&bar', { title: 'foo&bar' }, false],
      ['title:foo%26bar%26baz', title: 'foo&bar&baz'],
      ['title:foo&bar&baz', { title: 'foo&bar&baz' }, false],

      ['title:foo author:bar', title: 'foo', author: 'bar'],
      ['title:foo author:(bar baz)', title: 'foo', author: '(bar baz)'],
      ['title:foo -author:(bar baz)', title: 'foo', '-author' => '(bar baz)'],
      ['title:foo -author%26:(bar baz)', title: 'foo', '-author&' => '(bar baz)'],
      ['title:foo -author&:(bar baz)', { title: 'foo', '-author&' => '(bar baz)' }, false],

      ['title:foo author:bar author:baz', title: 'foo', author: %w[bar baz]],
      ['title:foo author:bar%26baz', title: 'foo', author: %w[bar&baz]],
      ['title:foo author:bar&baz', { title: 'foo', author: %w[bar&baz] }, false],
      ['title:foo -author:bar -author:baz', title: 'foo', '-author' => %w[bar baz]],
      ['title:foo -author%26:bar -author%26:baz', title: 'foo', '-author&' => %w[bar baz]],
      ['title:foo -author&:bar -author&:baz', { title: 'foo', '-author&' => %w[bar baz] }, false],

      ['{!q.op=AND}title:foo', title: 'foo', _: 'q.op=AND'],
      ['{!q.op=AND}title:foo author:bar', ['title:foo', author: 'bar', _: 'q.op=AND']],
      ['{!q.op=AND df=title}foo', ['foo', _: 'q.op=AND df=title']],
      ['{!q.op=AND df=title}foo', ['foo', _: %w[q.op=AND df=title]]],
      ['{!q.op=AND df=title}foo', ['foo', _: { 'q.op' => 'AND', df: :title }]]
    ].each_with_index { |(expected, *args), index|
      example(index) { expect(described_class.query_string(*args)).to eq(expected) }
    }

  end

  describe '::local_params_string' do

    [
      [nil, nil],
      [nil, ''],
      [nil, []],
      [nil, {}],

      ['{!q.op=AND df=title}', 'q.op=AND df=title'],
      ['{!q.op=AND df=title}', %w[q.op=AND df=title]],
      ['{!q.op=AND df=title}', 'q.op' => 'AND', df: :title],

      ['{!type=dismax qf="myfield yourfield"}', 'type=dismax qf="myfield yourfield"'],
      ['{!type=dismax qf="myfield yourfield"}', ['type=dismax', 'qf="myfield yourfield"']],
      ['{!type=dismax qf="myfield yourfield"}', type: :dismax, qf: 'myfield yourfield'],

      ['{!type=dismax qf="myfield%26yourfield"}', 'type=dismax qf="myfield&yourfield"'],
      ['{!type=dismax qf="myfield&yourfield"}', 'type=dismax qf="myfield&yourfield"', {}, false],
      ['{!type=dismax qf="myfield%26yourfield"}', ['type=dismax', 'qf="myfield&yourfield"']],
      ['{!type=dismax qf=myfield%26yourfield}', type: :dismax, qf: 'myfield&yourfield'],

      ['{!type=mlt qf=$mlt.fl mintf=$mlt.mintf mindf=$mlt.mindf minwl=$mlt.minwl maxwl=$mlt.maxwl}',
       'type=mlt qf=$mlt.fl mintf=$mlt.mintf mindf=$mlt.mindf minwl=$mlt.minwl maxwl=$mlt.maxwl'],
      ['{!type=mlt qf=$mlt.fl mintf=$mlt.mintf mindf=$mlt.mindf minwl=$mlt.minwl maxwl=$mlt.maxwl}',
       %w[type=mlt qf=$mlt.fl mintf=$mlt.mintf mindf=$mlt.mindf minwl=$mlt.minwl maxwl=$mlt.maxwl]],
      ['{!type=mlt qf=$mlt.fl mintf=$mlt.mintf mindf=$mlt.mindf minwl=$mlt.minwl maxwl=$mlt.maxwl}',
       %w[mintf mindf minwl maxwl], type: :mlt, qf: '$mlt.fl']
    ].each_with_index { |(expected, *args), index|
      example(index) { expect(described_class.local_params_string(*args)).to eq(expected) }
    }

  end

end
