/***************************************************************************
 * Copyright 2014 Kieker Project (http://kieker-monitoring.net)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ***************************************************************************/

package moobench.benchmark;

/**
 * @author Jan Waller, Christian Wulf
 */
public interface BenchmarkingThread extends Runnable {

  /**
   * @param index
   *          of the monitored call
   * @param separatorString
   *          used to separate the monitored entries
   * @return all monitored entries for the given <code>index</code> separated by the given
   *         <code>separatorString</code>
   */
  public String print(final int index, final String separatorString);
}
