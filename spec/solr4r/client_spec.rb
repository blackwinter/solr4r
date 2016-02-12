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

      ['date:1992-03-15', date: Date.new(1992, 03, 15)],
      ['time:"1992-03-15T15:23:55Z"', time: Time.new(1992, 03, 15, 16, 23, 55, 3600)],
      ['datetime:"1992-03-15T15:23:55Z"', datetime: DateTime.new(1992, 03, 15, 16, 23, 55, '+1')],

      ['stringrange:[a TO z]', stringrange: 'a'..'z'],
      ['integerrange:[15 TO 25]', integerrange: 15..25],
      ['floatrange:[-1.5 TO 2.5]', floatrange: -1.5..2.5],
      ['daterange:[1992-03-15 TO 1992-04-25]',
         daterange: Date.new(1992, 03, 15)..Date.new(1992, 04, 25)],
      ['timerange:["1992-03-15T15:23:55Z" TO "1992-04-25T15:23:55Z"]',
         timerange: Time.new(1992, 03, 15, 16, 23, 55, 3600)..Time.new(1992, 04, 25, 16, 23, 55, 3600)],
      ['datetimerange:["1992-03-15T15:23:55Z" TO "1992-04-25T15:23:55Z"]',
         datetimerange: DateTime.new(1992, 03, 15, 16, 23, 55, '+1')..DateTime.new(1992, 04, 25, 16, 23, 55, '+1')],

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

  describe 'requests', vcr: true do

    describe '#get' do

      def get(*args)
        res = subject.get(*args)

        expect(res).to be_success
        expect(res.response_code).to eq(200)

        res
      end

      it "should get /select" do
        res = get('select')

        expect(res.to_i).to eq(0)
        expect(res.to_s).to be_a(String)
        expect(res.result).to be_a(Solr4R::Result)
      end

      it "should get /select JSON result" do
        res = get('select', wt: :json)

        expect(res.to_i).to eq(0)
        expect(res.to_s).to be_a(String)
        expect(res.result).to be_a(Solr4R::Result)
      end

      it "should get /select JSON string" do
        res = get('select', wt: 'json')

        expect(res.to_i).to eq(0)
        expect(res.to_s).to be_a(String)
        expect(res.result).to be_a(String)
      end

      it "should get /select XML" do
        res = get('select', wt: 'xml')

        expect(res.to_i).to eq(0)
        expect(res.to_s).to be_a(String)
        expect(res.result).to be_a(String)
      end

      it "should get /select CSV" do
        res, err = get('select', wt: :csv), /:csv not supported/

        expect { res.to_i }.to raise_error(err)
        expect(res.to_s).to be_a(String)
        expect { res.result }.to raise_error(err)
      end

      it "should get /select FOO" do
        res, err = get('select', wt: 'foo'), /"foo" not supported/

        expect { res.to_i }.to raise_error(err)
        expect(res.to_s).to be_a(String)
        expect(res.result).to be_a(String)
      end

      it "should not get /foo" do
        res = subject.get('foo')

        expect(res).not_to be_success
        expect(res.response_code).to eq(404)
      end

    end

    describe '#json' do

      def expect_json(*args)
        res = subject.json('select', *args)

        expect(res).to be_a(Solr4R::Result)
        expect(res).to be_a(Solr4R::Result::Response)
        expect(res.to_i).to eq(0)
        expect(res).to be_empty
        expect(res).not_to be_error
      end

      it "should get /select JSON" do
        expect_json
      end

      it "should get /select JSON with wt symbol override" do
        expect_json(wt: 'foo')
      end

      it "should get /select JSON with wt string override" do
        expect_json('wt' => 'foo')
      end

    end

  end

end
