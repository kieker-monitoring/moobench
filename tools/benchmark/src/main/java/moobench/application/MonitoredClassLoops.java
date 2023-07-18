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

package moobench.application;

import java.util.Random;

/**
 * This class allows to add artificial overhead in the form of dummy loops into the monitored method. Thereby, it models "real" CPU usage 
 * (instead of just getting the time, which creates a lot of syscalls). 
 * @author DaGeRe
 */
public final class MonitoredClassLoops implements MonitoredClass {
	private static final int DUMMY_LOOPS = Integer.parseInt(System.getenv("DUMMY_LOOPS") != null ? System.getenv("DUMMY_LOOPS") : "15");
	
	private static final Random r = new Random();

	/**
	 * Default constructor.
	 */
	public MonitoredClassLoops() {
		// empty default constructor
	}

	public final long monitoredMethod(final long methodTime, final int recDepth) {
		if (recDepth > 1) {
			return this.monitoredMethod(methodTime, recDepth - 1);
		} else {
			int sum = 0;
			for (int i = 0; i < DUMMY_LOOPS; i++) {
				sum += r.nextInt();
			}
			return System.nanoTime() + sum % 2;
		}
	}
}
