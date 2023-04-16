#if defined _arrayqueue_included
  #endinput
#define _arrayqueue_included
#endif

methodmap ArrayQueue < ArrayList
{
	public ArrayQueue(int blocksize=1, int startsize=0)
	{
		return view_as< ArrayQueue >(new ArrayList(blocksize, startsize));
	}

	public void Enqueue(any data)
	{
		this.Push(data);
	}

	public void EnqueueString(const char[] data)
	{
		this.PushString(data);
	}

	public void EnqueueArray(const any[] data, int size=-1)
	{
		this.PushArray(data, size);
	}

	public any Peek()
	{
		return this.Get(0);
	}

	public int PeekArray(any[] array, int len=-1)
	{
		return this.GetArray(0, array, len);
	}

	public int PeekString(char[] str, int len)
	{
		return this.GetString(0, str, len);
	}

	public any Dequeue()
	{
		any val = this.Get(0);
		this.Erase(0);
		return val;
	}

	public bool DequeueEx(any &val)
	{
		if (this.Length)
		{
			val = this.Dequeue();
			return true;
		}
		return false;
	}

	public int DequeueArray(any[] array, int len=-1)
	{
		int ret = this.GetArray(0, array, len);
		this.Erase(0);
		return ret;
	}

	public bool DequeueArrayEx(any[] array, int len=-1, int &cellswritten=0)
	{
		if (this.Length)
		{
			cellswritten = this.DequeueArray(array, len);
			return true;
		}
		return false;
	}

	public int DequeueString(char[] str, int len)
	{
		int ret = this.GetString(0, str, len);
		this.Erase(0);
		return ret;
	}

	public bool DequeueStringEx(char[] str, int len, int &byteswritten=0)
	{
		if (this.Length)
		{
			byteswritten = this.DequeueString(str, len);
			return true;
		}
		return false;
	}
}